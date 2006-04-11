From: Tim Shepard <shep@alum.mit.edu>
Subject: Re: Re: created new q_disc, inserted module,
	tc tells me unknown qdisc
Date: Tue, 11 Apr 2006 16:29:41 -0400
Message-ID: <E1FTPUb-00017v-00@alva.home>
References: <3568.128.2.140.234.1144783610.squirrel@128.2.140.234>
Cc: netdev@vger.kernel.org, lartc@mailman.ds9a.nl
Return-path: <lartc-bounces@mailman.ds9a.nl>
To: "George P Nychis" <gnychis@cmu.edu>
In-reply-to: Your message of Tue, 11 Apr 2006 15:26:50 -0400.
	<3568.128.2.140.234.1144783610.squirrel@128.2.140.234>
List-Unsubscribe: <http://mailman.ds9a.nl/cgi-bin/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=unsubscribe>
List-Archive: <http://mailman.ds9a.nl/pipermail/lartc>
List-Post: <mailto:lartc@mailman.ds9a.nl>
List-Help: <mailto:lartc-request@mailman.ds9a.nl?subject=help>
List-Subscribe: <http://mailman.ds9a.nl/cgi-bin/mailman/listinfo/lartc>,
	<mailto:lartc-request@mailman.ds9a.nl?subject=subscribe>
Sender: lartc-bounces@mailman.ds9a.nl
Errors-To: lartc-bounces@mailman.ds9a.nl
List-Id: netdev.vger.kernel.org


> Maybe i should add debugging in tc.c and see if it sees the .so and fails to load it or something.

Yes.   I would do that next.

Compile tc with -g and then run it under gdb and step through that
part to see what happens.

			-Tim Shepard
			 shep@alum.mit.edu
