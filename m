From: "Leandro Oliveira da Silva" <lansoweb@hotmail.com>
Subject: RES: RES: RES: [Bugme-new] [Bug 11249] New: TC HTB hanging problem
Date: Tue, 5 Aug 2008 16:46:02 -0300
Message-ID: <BAY111-DAV11AA450D19672BF0DE9F1BC07B0@phx.gbl>
References: <bug-11249-10286@http.bugzilla.kernel.org/> <20080804105506.8b401320.akpm@linux-foundation.org> <BAY111-DAV13CEE254838554E11B28A0C0780@phx.gbl> <48977BBF.4090705@gmail.com> <000601c8f6f4$a3853b90$ea8fb2b0$@com> <20080805122916.GC6541@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "'Andrew Morton'" <akpm@linux-foundation.org>,
	<netdev@vger.kernel.org>, <bugme-daemon@bugzilla.kernel.org>
To: "'Jarek Poplawski'" <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc1-s19.bay0.hotmail.com ([65.54.246.91]:33936 "EHLO
	bay0-omc1-s19.bay0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756783AbYHETqG convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Aug 2008 15:46:06 -0400
In-Reply-To: <20080805122916.GC6541@ff.dom.local>
Message-ID: <002101c8f733$e40dc6c0$ac295440$@com>
Content-Language: pt-br
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jarek!

Good news. I downloaded the 2.6.26 version to one of my clients, compil=
ed,
and before the reboot to put this one as active I ran my script and the
server hanged. When they restarted the server the kernel 2.6.26 entered=
 and
I ran the script several times without problem. I guess in my case it w=
as
one of the two bugs, but I'm putting this kernel in other 3 servers and
let's see if they work fine now. I'll send a email on Friday with the
status.

Thanks a lot,
Leandro

-----Mensagem original-----
De: Jarek Poplawski [mailto:jarkao2@gmail.com]=20
Enviada em: ter=E7a-feira, 5 de agosto de 2008 09:29
Para: Leandro Oliveira da Silva
Cc: 'Andrew Morton'; netdev@vger.kernel.org;
bugme-daemon@bugzilla.kernel.org
Assunto: Re: RES: RES: [Bugme-new] [Bug 11249] New: TC HTB hanging prob=
lem

On Tue, Aug 05, 2008 at 09:13:15AM -0300, Leandro Oliveira da Silva wro=
te:
> Hello Jarek!
>=20
> Many thanks for your response! Are these two patches already included=
 in
> 2.6.26 version?

Yes.

> Thanks a lot again,

Not at all... at least until we know if it works!

Jarek P.

