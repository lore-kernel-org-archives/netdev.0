From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bonding driver has bad load balancing for forwarded traffic,
 3.7+
Date: Tue, 16 Apr 2013 06:51:33 -0700
Message-ID: <1366120293.4459.133.camel@edumazet-glaptop>
References: <516C075E.30105@telenet.dn.ua>
	  <1366072679.4459.113.camel@edumazet-glaptop>
	 <1366081404.4459.127.camel@edumazet-glaptop>
	 <516D1374.1070500@telenet.dn.ua>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Jay Vosburgh <fubar@us.ibm.com>,
	John Eaglesham <linux@8192.net>
To: "Vitaly V. Bursov" <vitalyb@telenet.dn.ua>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <516D1374.1070500@telenet.dn.ua>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2013-04-16 at 12:01 +0300, Vitaly V. Bursov wrote:

> Testing under real load for almost 2 hours now, works as expected.
> xmit_hash_policy=layer3+4
> 
> I made a few simple test with layer2+3 policy too, looks OK.
> 
> Thanks!

Perfect, thanks a lot for all this !

Tested-by: Vitaly V. Bursov <vitalyb@telenet.dn.ua>
