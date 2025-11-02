import { json } from '@sveltejs/kit';
import { PrismaClient } from '@prisma/client';
import { getLineForStudy } from '$lib/scheduler';

export async function GET({ url, locals }) {

	// session
	const session = await locals.auth.validate();
	if (!session) return json({ success: false, message: 'not logged in' });
	const userId = session.user.cdUserId;


	const prisma = new PrismaClient();

	const lastLineJson = url.searchParams.get('last');
	const lastLine = lastLineJson === null ? [] : JSON.parse( lastLineJson );

	const moves = await prisma.move.findMany({
		where: { userId, deleted: false }
	});

	let response = await getLineForStudy( moves, new Date(), lastLine );

	// grab title of move source
	const line = response.line
	if( line.length === 0 ) return json({ success: false, message: 'no line found' });

	const finalMoveId = line[ line.length-1 ].id;
	const finalMove = await prisma.move.findUniqueOrThrow({
		where: {id: finalMoveId },
		select: {
			studies: {
				select: { name: true },
			}
		}
	});
	if ( finalMove.studies.length > 0 ) {
		response.source_name = finalMove.studies[0].name;
	} else {
		// TODO handle pgn case
	}

	return json(response);
}

