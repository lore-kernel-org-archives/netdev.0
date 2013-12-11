From: Zhi Yong Wu <zwu.kernel@gmail.com>
Subject: Re: [PATCH 2/2] tun: remove useless codes in tun_chr_aio_read() and tun_recvmsg()
Date: Wed, 11 Dec 2013 11:24:11 +0800
Message-ID: <CAEH94Lj2Lc8CY_bnHjgqy4ebxKtdsKK4dqVe_=SZQJ-iMQJ1dQ@mail.gmail.com>
References: <52A74CD1.808@gmail.com>
	<20131210.140036.1328560146971385473.davem@davemloft.net>
	<CAEH94Li+9tNP_U-og7oSyez4stqUTJ6xGCPaCmTSkyNZsRTT7w@mail.gmail.com>
	<20131210.221912.1575828670029427023.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jason Wang <jasowang@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Vlad Yasevich <vyasevich@gmail.com>, netdev@vger.kernel.org,
	linux-kernel mlist <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20131210.221912.1575828670029427023.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 11, 2013 at 11:19 AM, David Miller <davem@davemloft.net> wrote:
> From: Zhi Yong Wu <zwu.kernel@gmail.com>
> Date: Wed, 11 Dec 2013 11:14:04 +0800
>
>> Only one reminder, since David has committed the two patches, you
>> maybe need to take their impact on your patches into account.
>
> I reverted these changes from net-next.
So rapid:), thanks for your reminder.



-- 
Regards,

Zhi Yong Wu
