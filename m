From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next 3/4] bpf: add support for persistent maps/progs
Date: Fri, 16 Oct 2015 18:44:01 -0500
Message-ID: <87mvviidku.fsf@x220.int.ebiederm.org>
References: <cover.1444956943.git.daniel@iogearbox.net>
	<ab1fceb2d68876d89bb2ebb3d2b45486d3cf2388.1444956943.git.daniel@iogearbox.net>
	<1445016105.1251655.412231129.6574D430@webmail.messagingengine.com>
	<5621371C.2000507@plumgrid.com> <56213A61.40509@iogearbox.net>
	<87d1welkp8.fsf@x220.int.ebiederm.org> <56214FAC.5060704@plumgrid.com>
	<87y4f2io9l.fsf@x220.int.ebiederm.org> <5621649A.80403@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	davem@davemloft.net, viro@ZenIV.linux.org.uk, tgraf@suug.ch,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexei Starovoitov <ast@kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:42423 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751201AbbJPXyI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2015 19:54:08 -0400
In-Reply-To: <5621649A.80403@plumgrid.com> (Alexei Starovoitov's message of
	"Fri, 16 Oct 2015 13:56:58 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexei Starovoitov <ast@plumgrid.com> writes:

> We can argue about api for 2nd, whether it's mount with fd=1234 string
> or else, but for the first mount style doesn't make sense.

Why does mount not make sense?  It is exactly what you are looking for
so why does it not make sense?

Eric
