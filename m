From: Alberto Manuel Brandao Simoes <albie@alfarrabio.di.uminho.pt>
Subject: Re: Fw: [Bugme-new] [Bug 3527] New: ssh does not work with 2.6.9rc3
Date: Fri, 08 Oct 2004 20:41:49 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4166ED7D.5040704@alfarrabio.di.uminho.pt>
References: <20041008104801.0dd96536.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20041008104801.0dd96536.akpm@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> hrm.   Could you check to see if it starts working OK after the machine=
 has been
> up for more than five minutes?

3 hours up, still same problem

kind regards,
Alberto

>=20
> Begin forwarded message:
>=20
> Date: Fri, 8 Oct 2004 09:26:51 -0700
> From: bugme-daemon@osdl.org
> To: bugme-new@lists.osdl.org
> Subject: [Bugme-new] [Bug 3527] New: ssh does not work with 2.6.9rc3
>=20
>=20
> http://bugme.osdl.org/show_bug.cgi?id=3D3527
>=20
>            Summary: ssh does not work with 2.6.9rc3
>     Kernel Version: 2.6.9 RC 3
>             Status: NEW
>           Severity: normal
>              Owner: other_other@kernel-bugs.osdl.org
>          Submitter: albie@alfarrabio.di.uminho.pt
>=20
>=20
> Distribution: Slackware 10
>=20
> Problem Description:
>  Had kernel 2.6.7 working correctly. It had a bug with my sis ethernet =
card.
> Upgraded to 2.6.8.1, and had problems with sata (bug #3521). So, tried =
the 2.6.9
> RC 3.=20
>=20
>  With this kernel, the sis ethernet bug is fixed (well, at least I can =
do a ping
> -f without losing packets), SATA works but... wonder... ssh doesn't.
>=20
> If I have a public key on other machine without passphrase, it works.
> If not....
>=20
> ssh_askpass: exec(/usr/libexec/ssh-askpass): No such file or directory
> Permission denied, please try again.
> ssh_askpass: exec(/usr/libexec/ssh-askpass): No such file or directory
> Permission denied, please try again.
> ssh_askpass: exec(/usr/libexec/ssh-askpass): No such file or directory
> Permission denied (publickey,password,keyboard-interactive).
>=20
> Now, that file really doesn't exist. But it isn't needed with the old k=
ernel.
> So, what 2.6.9 rc 3 has that 2.6.7 don't?
>=20
> Thanks,
> Alberto
>=20
> ------- You are receiving this mail because: -------
> You are on the CC list for the bug, or are watching someone who is.

--=20
Alberto Sim=F5es

Much as I hate to say it, the Computer Science view of language design
has gotten too inbred in recent years. The Computer Scientists should
pay more attention to the Linguists, who have a much better handle on
how people prefer to communicate.
             --Larry Wall
