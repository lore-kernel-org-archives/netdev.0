From: "Alejandro Bonilla" <abonilla@linuxwireless.org>
Subject: RE: Problems with Broadcom and Intel PRO/1000 cards
Date: Thu, 2 Jun 2005 07:04:43 -0600
Message-ID: <001c01c56773$a5684060$600cc60a@amer.sykes.com>
References: <200506021238.25615.jtbbesaa@aintel.bi.ehu.es>
Reply-To: <abonilla@linuxwireless.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: "'Alfredo Beaumont Sainz'" <jtbbesaa@bipt106.bi.ehu.es>,
        <netdev@oss.sgi.com>
In-Reply-To: <200506021238.25615.jtbbesaa@aintel.bi.ehu.es>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> Hi,
>
> I've a dual opteron machine with an integrated dual Broadcom
> 5704 10/100/1000
> (tg3 driver) and an Intel PRO/1000 MT (e1000 driver). It
> seems that I cannot
> make them work a Gbps. I've a crossover cable connecting a
> interface of the
> Broadcom (eth1) with the Intel (eth2), but they connect at 100Mbps:
>

Only time that I have seen this before, it was because I was using an
incorrect cable. Make sure you have the _REAL_ Gb crossover cable.

http://logout.sh/computers/net/gigabit/

Also, I would trust in dmesg and not in some other tool.

.Alejandro
