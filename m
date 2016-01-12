From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] bonding: make device count build-time configurable
Date: Tue, 12 Jan 2016 15:49:14 -0500 (EST)
Message-ID: <20160112.154914.397367508465928770.davem@davemloft.net>
References: <1452599916-27511-1-git-send-email-lkundrak@v3.sk>
	<8166.1452616452@famine>
	<1452619189.18559.83.camel@v3.sk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jay.vosburgh@canonical.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, vfalico@gmail.com,
	gospo@cumulusnetworks.com
To: lkundrak@v3.sk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452619189.18559.83.camel@v3.sk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Lubomir Rintel <lkundrak@v3.sk>
Date: Tue, 12 Jan 2016 18:19:49 +0100

> It's still an improvement to let the distributions decide if they're
> keeping "ip link add" broken or possibly affecting the scripts.

That it is "broken" is your opinion.

Document the behavior.  It is not broken if the user is told to be
mindful of what devices are created by default.

There is way too much downside to changing this.
