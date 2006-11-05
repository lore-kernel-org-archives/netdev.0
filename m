From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 01/02 V3] net/ipv6: seperate sit driver to extra module
Date: Mon, 06 Nov 2006 00:38:14 +0100
Message-ID: <454E75E6.7010500@trash.net>
References: <45301CB3.4060803@l4x.org>	<20061014093255.GA4646@zlug.org>	<454E671B.2090302@trash.net> <20061105.152718.88476049.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: joro-lkml@zlug.org, jdi@l4x.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1422825AbWKEXie@vger.kernel.org>
To: David Miller <davem@davemloft.net>
In-Reply-To: <20061105.152718.88476049.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> Would you like me to apply this or is this a temp workaround
> for folks?

Please apply it. I usually build things as module if possible,
which in this case caused my tunnel to break. This will
probably happen to others as well.
