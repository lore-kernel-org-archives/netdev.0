From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.33/1 00/12] WiMAX patches for 2.6.33 (batch #1)
Date: Wed, 04 Nov 2009 22:24:50 -0800 (PST)
Message-ID: <20091104.222450.149379897.davem@davemloft.net>
References: <cover.1257370735.git.inaky@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wimax@linuxwimax.org
To: inaky@linux.intel.com
Return-path: <wimax-bounces@linuxwimax.org>
In-Reply-To: <cover.1257370735.git.inaky@linux.intel.com>
List-Unsubscribe: <http://lists.linuxwimax.org/options/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=unsubscribe>
List-Archive: <http://lists.linuxwimax.org/pipermail/wimax>
List-Post: <mailto:wimax@linuxwimax.org>
List-Help: <mailto:wimax-request@linuxwimax.org?subject=help>
List-Subscribe: <http://lists.linuxwimax.org/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=subscribe>
Sender: wimax-bounces@linuxwimax.org
Errors-To: wimax-bounces@linuxwimax.org
List-Id: netdev.vger.kernel.org

From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Date: Wed,  4 Nov 2009 13:39:36 -0800

> Please pull from:
> 
>   git://git.kernel.org/pub/scm/linux/kernel/git/inaky/wimax.git

Well you screwed up the patch posting and you screwed up the
GIT tree too :-/

This git tree is not based upon a clone of net-next-2.6, instead
it's a mish-mash of net-next-2.6 and some by-hand net-2.6
pulls you've done yourself.

Do NOT do this.

I even saw a random kbuild: change in there as well, which
also shouldn't have been there.

Fix up your tree and make it pull cleanly before submitting this
work again.

Also, when you give ma GIT URL you have to give me the branch to pull
from at the end of the URL, if I just give that URL without the branch
specifier to GIT for the pull it's going to fail.
