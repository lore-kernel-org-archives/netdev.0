From: Randy Dunlap <rdunlap@infradead.org>
Subject: Re: mmotm 2014-05-09-16-17 uploaded (ptrace-ab.hi vs. net/core/filter.c)
Date: Sat, 10 May 2014 10:15:37 -0700
Message-ID: <536E5EB9.5060101@infradead.org>
References: <20140509231825.22D005A4123@corp2gmr1-2.hot.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Richard Weinberger <richard@nod.at>
To: akpm@linux-foundation.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-kernel@vger.kernel.org, linux-next@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140509231825.22D005A4123@corp2gmr1-2.hot.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 05/09/2014 04:18 PM, akpm@linux-foundation.org wrote:
> The mm-of-the-moment snapshot 2014-05-09-16-17 has been uploaded to
> 
>    http://www.ozlabs.org/~akpm/mmotm/
> 


uml defconfig on x86_64: (also happens in linux-next)

net/core/filter.c:57:0: warning: "R8" redefined [enabled by default]
arch/x86/include/uapi/asm/ptrace-abi.h:38:0: note: this is the location of the previous definition

Same warnings for R9 and R10.

-- 
~Randy
