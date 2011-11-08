From: Daniil Stolnikov <danila.st@mail.ru>
Subject: Add IPSec IP Range in Linux kernel
Date: Tue, 8 Nov 2011 11:10:36 +0800
Message-ID: <92909814.20111108111036@mail.ru>
Reply-To: Daniil Stolnikov <danila.st@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1251
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, linux-crypto@vger.kernel.org,
	<linux-security-module@vger.kernel.org>, <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

Found that the stack IPSec in Linux does not support any IP range. Many people ask this question. The archives say strongswan said that their daemon supports a range, but the Linux IPSec stack supports only the subnets. I am writing to you to implement support for IP range in Linux. I think that a lot more people will appreciate this innovation.


Regards
Daniil Stolnikov.
