From: Michal Marek <mmarek@suse.cz>
Subject: Re: [PATCH 31/40] trace syscalls: Convert various generic compat
 syscalls
Date: Thu, 24 Jun 2010 14:05:07 +0200
Message-ID: <4C2349F3.7090207__25301.649401854$1277381425$gmane$org@suse.cz>
References: <1277287401-28571-1-git-send-email-imunsie@au1.ibm.com> <1277287401-28571-32-git-send-email-imunsie@au1.ibm.com> <4C21DFBA.2070202@linux.intel.com> <20100623102931.GB5242@nowhere> <4C21E3F8.9000405@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,linuxppc-dev@ozlabs.org,linux-fsdevel@vger.kernel.org,kexec@lists.infradead.org,netdev@vger.kernel.org
To: linux-mm@kvack.org
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <4C21E3F8.9000405@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On 23.6.2010 12:37, Andi Kleen wrote:
> It also has maintenance costs, e.g. I doubt ctags and cscope
> will be able to deal with these kinds of macros, so it has a
> high cost for everyone using these tools.

FWIW, patch 16/40 of this series teaches 'make tags' to recognize these
macros: http://permalink.gmane.org/gmane.linux.kernel/1002103

Michal

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
