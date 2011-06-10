From: =?UTF-8?Q?R=C3=A9mi_Denis-Courmont?= <remi@remlab.net>
Subject: Re: [PATCH net-2.6.23] Per-datagram TTL and TOS via sendmsg()
Date: Fri, 10 Jun 2011 09:24:28 +0200
Message-ID: <361fb66ec9a3f9788ba1ad24562b2166@chewa.net>
References: <180685543D224348869F70A5870DB9408A5EE7D2@USNAVSXCHMBSB2.ndc.alcatel-lucent.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "Miljanovic, Nebojsa (Neb)" <neb.miljanovic@alcatel-lucent.com>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:38892 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752106Ab1FJHYa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jun 2011 03:24:30 -0400
In-Reply-To: <180685543D224348869F70A5870DB9408A5EE7D2@USNAVSXCHMBSB2.ndc.alcatel-lucent.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 9 Jun 2011 08:20:46 -0500, "Miljanovic, Nebojsa (Neb)"=0D
<neb.miljanovic@alcatel-lucent.com> wrote:=0D
> is there any way to get this old PATCH accepted. I am finding it very=
=0D
> useful since the only other way to control TOS/DSCP is via socket=0D
option.=0D
> However, socket wide TOS/DSCP is not always practical. Having ability=
=0D
for=0D
> applications to control TOS/DSCP on per-datagram basis is so much mor=
e=0D
> powerful.=0D
=0D
I have not tried, but with 17 kernel passed, it is safe to assume that=0D
this patch cannot be applied as is.=0D
=0D
-- =0D
R=C3=A9mi Denis-Courmont=0D
http://www.remlab.net/
