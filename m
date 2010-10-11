From: =?UTF-8?Q?R=C3=A9mi_Denis-Courmont?= <remi@remlab.net>
Subject: Re: [PATCH 4/4] Phonet: mark the pipe controller as EXPERIMENTAL
Date: Mon, 11 Oct 2010 10:24:18 +0200
Message-ID: <56d85553d22d9490e2e94e5960e0f9de@chewa.net>
References: <1286546523-3340-1-git-send-email-remi@remlab.net> <1286546523-3340-2-git-send-email-remi@remlab.net> <1286546523-3340-3-git-send-email-remi@remlab.net> <1286546523-3340-4-git-send-email-remi@remlab.net> <20101011070928.GC31124@bnru01.bnr.st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Kumar SANGHVI <kumar.sanghvi@stericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:60484 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753283Ab0JKIYU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Oct 2010 04:24:20 -0400
In-Reply-To: <20101011070928.GC31124@bnru01.bnr.st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 11 Oct 2010 12:39:29 +0530, Kumar SANGHVI=0D
<kumar.sanghvi@stericsson.com> wrote:=0D
> I have already started implementing 'connect()' socket call for Pipe=0D
> controller logic, as per advise of R=C3=A9mi Denis-Courmontt. I will =
upload=0D
> this patch for review once I have validated GPRS/3G path (control/dat=
a)=0D
> to be working fine.=0D
> =0D
> Hopefully, with all the reviews and suggestions shared on the mailing=
=0D
> list, existing abuse can be removed and new abuses can be avoided.=0D
> =0D
> The only intention of submitting is to make Linux work smoothly with=0D
> newer devices. If there is some improper code getting introduced=0D
> unknowingly, then I will surely work on the review comments to fix it=
=2E=0D
=0D
I am sure everybody wants to get things right eventually. That's not mu=
ch=0D
of a concern to me.=0D
=0D
However, I am concerned that Linux 2.6.37 ships with an unfinished=0D
implementation, or worse, an unfinished user-space interface.=0D
=0D
-- =0D
R=C3=A9mi Denis-Courmont=0D
http://www.remlab.net=0D
http://fi.linkedin.com/in/remidenis

