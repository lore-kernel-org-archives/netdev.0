From: Tariq Toukan <ttoukan.linux@gmail.com>
Subject: Re: [PATCH v8 00/11] Add driver bpf hook for early packet drop and
 forwarding
Date: Wed, 13 Jul 2016 18:00:31 +0300
Message-ID: <c37f1397-2a1c-580d-2b9f-bb6391836cf4@gmail.com>
References: <1468309894-26258-1-git-send-email-bblanco@plumgrid.com>
 <7e33d1b5-7900-6982-9c31-e61da33a434a@gmail.com>
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
Received: from mail-wm0-f45.google.com ([74.125.82.45]:36545 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751244AbcGMPBN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2016 11:01:13 -0400
Received: by mail-wm0-f45.google.com with SMTP id f126so32841588wma.1
        for <netdev@vger.kernel.org>; Wed, 13 Jul 2016 08:01:03 -0700 (PDT)
In-Reply-To: <7e33d1b5-7900-6982-9c31-e61da33a434a@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 12/07/2016 5:38 PM, Tariq Toukan wrote:
> Regression tests for mlx4_en are currently running, results will be 
> ready by tomorrow morning.
Functional regression results look fine.
>
> Regards,
> Tariq
