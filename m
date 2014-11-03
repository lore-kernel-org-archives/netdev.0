From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net: eth: realtek: atp: checkpatch errors and warnings
 corrected
Date: Mon, 03 Nov 2014 10:51:26 -0800
Message-ID: <1415040686.17743.31.camel@perches.com>
References: <1415039073-20164-1-git-send-email-robertoxmed@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Roberto Medina <robertoxmed@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415039073-20164-1-git-send-email-robertoxmed@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-11-03 at 19:24 +0100, Roberto Medina wrote:
> From: Roberto Medina <robertoxmed@gmail.com>
> 
> Several warnings and errors corrected using checkpatch.
> Some warnings like "line over 80" are still present.
> 
> Before the patch:
> 	total: 16 errors, 155 warnings, 38 checks, 883 lines checked
> 
> With the patch:
> 	total: 0 errors, 64 warnings, 24 checks, 905 lines checked
> 	
> Compile tested.

Some ancient drivers could be regarded as neolithic
curiosities that never need updating.  This may be one.

But if you really want to change it, could you please
make sure that objdiff shows no changes?
