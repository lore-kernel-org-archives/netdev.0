From: Jeff Garzik <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/3] orinoco: WE-18 support
Date: Wed, 14 Sep 2005 08:31:32 -0400
Message-ID: <43281824.7000705@pobox.com>
References: <1126305782.16679.5.camel@dv>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Orinoco Development List <orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Jean Tourrilhes <jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org>
Return-path: <orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
In-Reply-To: <1126305782.16679.5.camel@dv>
Sender: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Post: <mailto:orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/orinoco-devel>,
	<mailto:orinoco-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=orinoco-devel>
List-Id: netdev.vger.kernel.org

Pavel Roskin wrote:
> Author: Jean Tourrilhes <jt-sDzT885Ts8HQT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
> 
> Use new Wireless Extension API for wireless stats.

Applied patch #1, the rest failed:


[jgarzik@pretzel netdev-2.6]$ applymbox /g/tmp/mbox ~/info/signoff.txt

Applying 'orinoco: WE-18 support'

Wrote tree 2713fbd5e71f7a7dbe94634a1bc4eb81a1ed8af5
Committed: 343c686c04eec556645f251f7d6c9b3d7335dae0

Applying 'orinoco: Update PCMCIA ID's'

error: patch failed: drivers/net/wireless/orinoco_cs.c:601
error: drivers/net/wireless/orinoco_cs.c: patch does not apply



-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
