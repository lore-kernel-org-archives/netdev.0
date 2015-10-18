From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 3/4] bpf: add support for persistent maps/progs
Date: Sun, 18 Oct 2015 17:03:16 +0200
Message-ID: <5623B4B4.2010703@iogearbox.net>
References: <cover.1444956943.git.daniel@iogearbox.net> <ab1fceb2d68876d89bb2ebb3d2b45486d3cf2388.1444956943.git.daniel@iogearbox.net> <1445016105.1251655.412231129.6574D430@webmail.messagingengine.com> <5621371C.2000507@plumgrid.com> <56213A61.40509@iogearbox.net> <87d1welkp8.fsf@x220.int.ebiederm.org> <56214FAC.5060704@plumgrid.com> <87y4f2io9l.fsf@x220.int.ebiederm.org> <5621649A.80403@plumgrid.com> <87mvviidku.fsf@x220.int.ebiederm.org> <5621B5BC.8020204@plumgrid.com> <56223F00.5030203@iogearbox.net> <562301F9.1030702@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	davem@davemloft.net, viro@ZenIV.linux.org.uk, tgraf@suug.ch,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexei Starovoitov <ast@kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:44457 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752766AbbJRPDo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Oct 2015 11:03:44 -0400
In-Reply-To: <562301F9.1030702@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/18/2015 04:20 AM, Alexei Starovoitov wrote:
...
> that indeed sounds cleaner, less lines of code, no fs, etc, but
> I don't see how it will work yet.

I'll have some code ready very soon to show the concept. Will post it here
tonight, stay tuned. ;)

Cheers,
Daniel
