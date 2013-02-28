From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [PATCH] drivers/isdn: checkng length to be sure not memory overflow
Date: Thu, 28 Feb 2013 09:45:46 +0800
Message-ID: <512EB6CA.6030609@asianux.com>
References: <512DCC4A.6060106@asianux.com> <512DD66E.4040409@suse.cz> <512DDF03.10107@asianux.com> <512DE380.8080804@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jiri Kosina <jkosina@suse.cz>, isdn@linux-pingi.de,
	Greg KH <gregkh@linuxfoundation.org>, alan@linux.intel.com,
	netdev <netdev@vger.kernel.org>
To: Jiri Slaby <jslaby@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:8385 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752587Ab3B1BqK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Feb 2013 20:46:10 -0500
In-Reply-To: <512DE380.8080804@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2013=E5=B9=B402=E6=9C=8827=E6=97=A5 18:44, Jiri Slaby =E5=86=99=
=E9=81=93:
> On 02/27/2013 11:25 AM, Chen Gang wrote:
>> > =E4=BA=8E 2013=E5=B9=B402=E6=9C=8827=E6=97=A5 17:48, Jiri Slaby =E5=
=86=99=E9=81=93:
>>> >> I have no idea if
>>> >> this is correct from the ISDN POV as we drop the end of the buff=
er
>> >=20
>> >   pardon ?  what about "ISDN POV".
> "point of view" aka POV.
>=20
> Hmm, "also known as" alias "aka" :).


  sorry, I still not quite understand (I am really not familiar with IS=
DN)

  so I have to bother you with 2 questions, please help reply, thanks.

    A) is our current patch OK ?
       a. yes, ok, need do nothing for it, just is waiting for Acked-by=
 or applying.
       b. no, need improving (e.g. additional consideration, comments, =
or others)
       c. no, it is useless patch.

    B) does "ISDN POV" point to another issue ?
       if yes:
         I will read source code or search document on net, and should =
not bother you again.
         if possible, I can try to send relative patches, next.
       else (no):
         could you please say more details again ?
         I should improve current patch (also need let you as Signed-of=
-By)

  thanks.

  :-)

--=20
Chen Gang

Asianux Corporation
