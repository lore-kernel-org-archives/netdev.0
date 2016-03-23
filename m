From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 1/2] net: ethernet: dlink: dl2k: fix code style
Date: Wed, 23 Mar 2016 07:50:01 -0700
Message-ID: <1458744601.6819.4.camel@perches.com>
References: <1458743800-30606-1-git-send-email-mussitantesmortem@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux@rainbow-software.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Maxim Zhukov <mussitantesmortem@gmail.com>, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1458743800-30606-1-git-send-email-mussitantesmortem@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2016-03-23 at 17:36 +0300, Maxim Zhukov wrote:
> This commit fixed spacing errors and warnings.

This commit log should show that you've tested this
by stating something like:
	"git diff -w shows no difference"
and
	"objdiff shows no changes"

If objdiff shows changes, you need to be show
why it's OK.
