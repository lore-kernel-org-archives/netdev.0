From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] skbuff: optimize the pull_pages code in
 __pskb_pull_tail()
Date: Thu, 06 Jul 2017 02:48:36 -0700
Message-ID: <1499334516.16045.16.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1499331694-34678-1-git-send-email-xiaolou4617@gmail.com>
         <1499332587.16045.13.camel@edumazet-glaptop3.roam.corp.google.com>
         <1499333003.16045.15.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAGd-6ZeegG2wRg19kNs6ZzEMxtXKMKUL2+=AiTjHOxNDDGM6RQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: lin zhang <xiaolou4617@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAGd-6ZeegG2wRg19kNs6ZzEMxtXKMKUL2+=AiTjHOxNDDGM6RQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2017-07-06 at 17:35 +0800, lin zhang wrote:

> thanks, i am a newer, "net-next is closed" it means i need repost it
> after net-next reopened?

Yes, please read Documentation/networking/netdev-FAQ.txt for details.
