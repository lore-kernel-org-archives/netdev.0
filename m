From: Tariq Toukan <ttoukan.linux@gmail.com>
Subject: Re: [PATCH v9 00/11] Add driver bpf hook for early packet drop and
 forwarding
Date: Mon, 18 Jul 2016 16:39:38 +0300
Message-ID: <f94302fd-da02-c03d-e9ab-5292e6594b10@gmail.com>
References: <1468625338-32391-1-git-send-email-bblanco@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Saeed Mahameed <saeedm@dev.mellanox.co.il>,
	Martin KaFai Lau <kafai@fb.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Ari Saha <as754m@att.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Or Gerlitz <gerlitz.or@gmail.com>, john.fastabend@gmail.com,
	hannes@stressinduktion.org, Thomas Graf <tgraf@suug.ch>,
	Tom Herbert <tom@herbertland.com>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Brenden Blanco <bblanco@plumgrid.com>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:36986 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751490AbcGRNjn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 09:39:43 -0400
Received: by mail-wm0-f51.google.com with SMTP id i5so117308843wmg.0
        for <netdev@vger.kernel.org>; Mon, 18 Jul 2016 06:39:43 -0700 (PDT)
In-Reply-To: <1468625338-32391-1-git-send-email-bblanco@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After applying the patchset, I get no ping between two VLAN interfaces 
(w/o activating any BPF program).
I'm debugging it, and will update once I find the bug.

Brenden, please check if you can repro the issue.

Regards,
Tariq
