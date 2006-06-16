From: "Mayuresh Chitale" <mchitale@gmail.com>
Subject: Linux 2.6 Vs linux 2.4 routing
Date: Sat, 17 Jun 2006 00:11:19 +0530
Message-ID: <d096a3ee0606161141n3c481ed9kfcbf70af7393affa@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <linux-net-owner@vger.kernel.org>
To: netdev@vger.kernel.org, linux-net@vger.kernel.org
Content-Disposition: inline
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi All,

I am doing a routing test using linux 2.4 and linux 2.6 kernel on our
board. I am using 2.4.31 and 2.6.16.17 for comparison.

I have ported the bsp and drivers from 2.4 to 2.6 and am using a
smartbits tester which pumps traffic at high rates and at varying
packet sizes.

On 2.4, the test goes fine ie I get meaningful values. But on 2.6
kernel, routing begins and continues for sometime before it completely
stops. The smartbits configuration is identical in both the cases.

I have noticed same problem with dlink and 3com cards which is causing
me to suspect that there is some probem with 2.6 routing.

Has anyone seen a similar problem ?
Any inputs on this would be appreciated.

Thanks,
Mayuresh.
