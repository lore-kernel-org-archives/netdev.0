From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: do not initialise statics to 0
Date: Thu, 16 Jun 2016 17:41:33 -0700 (PDT)
Message-ID: <20160616.174133.1188768780443830614.davem@davemloft.net>
References: <1466083069-9603-1-git-send-email-tangwei@cmss.chinamobile.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, aduyck@mirantis.com, jiri@mellanox.com,
	jarod@redhat.com, nikolay@cumulusnetworks.com, ast@plumgrid.com,
	tom@herbertland.com, daniel@iogearbox.net, ja@ssi.bg,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: tangwei@cmss.chinamobile.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1466083069-9603-1-git-send-email-tangwei@cmss.chinamobile.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Wei Tang <tangwei@cmss.chinamobile.com>
Date: Thu, 16 Jun 2016 21:17:49 +0800

> This patch fixes the checkpatch.pl error to dev.c:
> 
> ERROR: do not initialise statics to 0
> 
> Signed-off-by: Wei Tang <tangwei@cmss.chinamobile.com>

Applied.
