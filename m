From: Tariq Toukan <tariqt@mellanox.com>
Subject: RE: [PATCH v8 08/11] net/mlx4_en: break out tx_desc write into
 separate function
Date: Tue, 12 Jul 2016 12:16:53 +0000
Message-ID: <AM4PR05MB15534566CD38635FA3C81963AE300@AM4PR05MB1553.eurprd05.prod.outlook.com>
References: <1468309894-26258-1-git-send-email-bblanco@plumgrid.com>
 <1468309894-26258-9-git-send-email-bblanco@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Saeed Mahameed <saeedm@dev.mellanox.co.il>,
	Martin KaFai Lau <kafai@fb.com>,
	"Jesper Dangaard Brouer" <brouer@redhat.com>,
	Ari Saha <as754m@att.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	Or Gerlitz <gerlitz.or@gmail.com>,
	"john.fastabend@gmail.com" <john.fastabend@gmail.com>,
	"hannes@stressinduktion.org" <hannes@stressinduktion.org>,
	Thomas Graf <tgraf@suug.ch>, Tom Herbert <tom@herbertland.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Tariq Toukan <ttoukan.linux@gmail.com>
To: Brenden Blanco <bblanco@plumgrid.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0071.outbound.protection.outlook.com ([104.47.2.71]:15370
	"EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932991AbcGLMQ4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2016 08:16:56 -0400
In-Reply-To: <1468309894-26258-9-git-send-email-bblanco@plumgrid.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>In preparation for writing the tx descriptor from multiple functions, create a helper for both normal and blueflame access.
>
>Signed-off-by: Brenden Blanco <bblanco@plumgrid.com>

Reviewed-by: Tariq Toukan <tariqt@mellanox.com>
