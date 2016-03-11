From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net-next 04/13] net/mlx5e: Use only close NUMA node for
 default RSS
Date: Fri, 11 Mar 2016 21:29:15 +0200
Message-ID: <CALzJLG8Hro2S5TKP0eHnN0RkE_6+UwEfPZ=zygXDD_5dP-WEow@mail.gmail.com>
References: <1457703594-9482-1-git-send-email-saeedm@mellanox.com>
	<1457703594-9482-5-git-send-email-saeedm@mellanox.com>
	<56E2D177.3090403@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Tariq Toukan <tariqt@mellanox.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f196.google.com ([209.85.160.196]:33482 "EHLO
	mail-yk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932070AbcCKT3Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2016 14:29:16 -0500
Received: by mail-yk0-f196.google.com with SMTP id r203so3451252ykd.0
        for <netdev@vger.kernel.org>; Fri, 11 Mar 2016 11:29:16 -0800 (PST)
In-Reply-To: <56E2D177.3090403@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 11, 2016 at 4:08 PM, Sergei Shtylyov
<sergei.shtylyov@cogentembedded.com> wrote:
> Hello.
>
> On 3/11/2016 4:39 PM, Saeed Mahameed wrote:
>
>> From: Tariq Toukan <tariqt@mellanox.com>
>>
>> Distribute default RSS table uniformely over the rings of the
>
>
>    Uniformly.

Indeed :), will fix this

Thank you.
