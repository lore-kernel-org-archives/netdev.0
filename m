From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 1/1 linux-next] zd1201: replace kmalloc/memset by kzalloc
Date: Thu, 16 Oct 2014 01:50:41 -0700
Message-ID: <1413449441.7484.22.camel@perches.com>
References: <1413304831-7203-1-git-send-email-fabf@skynet.be>
	 <1413306955.3269.30.camel@joe-AO725> <87iojm8qxp.fsf@nemi.mork.no>
	 <346236957.6316.1413446930736.open-xchange@webmail.nmp.skynet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>
To: Fabian Frederick <fabf@skynet.be>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <346236957.6316.1413446930736.open-xchange@webmail.nmp.skynet.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2014-10-16 at 10:08 +0200, Fabian Frederick wrote:
> Adding a structure would be a nice design update indeed but this would require
> some testing...Separate patch maybe ?

Of course that'd be fine.
