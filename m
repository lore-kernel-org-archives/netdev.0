From: Jeff Garzik <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 1/5] orinoco: Remove conditionals that are useless in
 the	kernel drivers.
Date: Fri, 16 Sep 2005 02:57:20 -0400
Message-ID: <432A6CD0.20108@pobox.com>
References: <1126851313.3056.2.camel@dv>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Orinoco Development List <orinoco-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Return-path: <orinoco-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Pavel Roskin <proski-mXXj517/zsQ@public.gmane.org>
In-Reply-To: <1126851313.3056.2.camel@dv>
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

applied patch 1-3, and then stopped:

Applying 'orinoco: Remove conditionals that are useless in the kernel 
drivers.'

Wrote tree 38c3d8007e70992829271a2fcf453624d4afadd2
Committed: 65853b133d0256786df25f03eea0e5a6799e8d17

Applying 'orinoco: Don't include <net/ieee80211.h> twice.'

Wrote tree 78dd96949dcb026a37f182255db3d804a4274706
Committed: 27c91efba4c121f90c0e6d371c7064733b286a69

Applying 'orinoco: Update PCMCIA ID's.'

Wrote tree a183ce73c486bfe86ea5e96e9619f2088784bbae
Committed: 9c8a11d7c2298680ff3ee8acda54575c88668bfc

Applying 'orinoco: Add support for WE-16 and WE-17'

error: patch failed: drivers/net/wireless/orinoco.c:133
error: drivers/net/wireless/orinoco.c: patch does not apply
error: patch failed: drivers/net/wireless/orinoco.h:11
error: drivers/net/wireless/orinoco.h: patch does not apply




-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
