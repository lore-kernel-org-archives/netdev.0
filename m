From: Pavel Fedin <p.fedin@samsung.com>
Subject: RE: [PATCH 3/6] net: thunderx: Increase transmit queue length
Date: Wed, 02 Dec 2015 11:09:15 +0300
Message-ID: <00b101d12cd8$bd34fea0$379efbe0$@samsung.com>
References: <y@samsung.com>
 <1448961223-41888-4-git-send-email-sunil.kovvuri@gmail.com>
 <01d101d12c46$2de43b40$89acb1c0$@samsung.com>
 <1448983985.25582.35.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: 'Sunil Goutham' <sunil.kovvuri@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Sunil.Goutham@caviumnetworks.com,
	'Sunil Goutham' <sgoutham@cavium.com>
To: 'Eric Dumazet' <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <1448983985.25582.35.camel@edumazet-glaptop2.roam.corp.google.com>
Content-language: ru
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 Hello!

> > swiotlb: coherent allocation failed for device 0002:01:08.4 size=4198400
> > CPU: 2 PID: 3655 Comm: NetworkManager Tainted: G        W  O    4.2.6+ #201
> > Hardware name: Cavium ThunderX CN88XX
> 
> Are you sure 4.2.6 kernel is suitable for backporting this patch aimed
> for linux-4.5 ?

 Why not? It's just a networking driver. And, i also have the same problem on 4.3 running as KVM guest with VFIO.

Kind regards,
Pavel Fedin
Expert Engineer
Samsung Electronics Research center Russia
