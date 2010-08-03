From: =?UTF-8?Q?R=C3=A9mi_Denis-Courmont?= <remi@remlab.net>
Subject: Re: RFC: New BPF 'LOOP' instruction
Date: Tue, 03 Aug 2010 16:16:02 +0200
Message-ID: <f350f48de92da479bfb224527bc70c10@chewa.net>
References: <20100803070426.GN11110@cel.leo> <20100803.001809.25133218.davem@davemloft.net> <87mxt3etut.fsf@basil.nowhere.org> <20100803.060754.26959298.davem@davemloft.net> <20100803133442.GQ11110@cel.leo> <72ff93eb4581b198faa6ce62d2b5162b@chewa.net> <20100803141313.GU11110@cel.leo>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Paul LeoNerd Evans <leonerd@leonerd.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:48598 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755897Ab0HCOQE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Aug 2010 10:16:04 -0400
In-Reply-To: <20100803141313.GU11110@cel.leo>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 3 Aug 2010 15:13:13 +0100, Paul LeoNerd Evans=0D
<leonerd@leonerd.org.uk> wrote:=0D
> Is there any way it could be done lazily, at the moment that filter.c=
=0D
> knows it has to provide either SKF_TRANS_OFF or SKF_AD_TRANSPROTO?=0D
=0D
You would essentially need to implement dedicated parsing for each=0D
protocols family.=0D
So you might as well add an opcode dedicated to IPv6...=0D
=0D
-- =0D
R=C3=A9mi Denis-Courmont=0D
http://www.remlab.net=0D
http://fi.linkedin.com/in/remidenis

