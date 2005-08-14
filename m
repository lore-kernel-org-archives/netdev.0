From: Patrick McHardy <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>
Subject: Re: [PATCH ppp-2.4.3] add SC_MUST_COMPRESS flag
Date: Sun, 14 Aug 2005 16:27:47 +0200
Message-ID: <42FF54E3.8000808@trash.net>
References: <42B747C9.7060901@pobox.com> <17102.26269.264419.345257@cargo.ozlabs.ibm.com> <17102.30763.326707.473425@cargo.ozlabs.ibm.com> <20050814141046.GB20944@lists.us.dell.com> <20050814141810.GC20944@lists.us.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>,
	Jeff Garzik <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, akpm-3NddpPZAyC0@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Brice.Goglin-vYW+cPY1g1pg9hUCZPvPmw@public.gmane.org,
	james.cameron-VXdhtT5mjnY@public.gmane.org, pptpclient-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Return-path: <pptpclient-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
To: Matt Domsch <Matt_Domsch-8PEkshWhKlo@public.gmane.org>
In-Reply-To: <20050814141810.GC20944-XtjxT7Vmt5ZskZv2Y/7f+AC/G2K4zDHf@public.gmane.org>
Sender: pptpclient-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
Errors-To: pptpclient-devel-admin-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/pptpclient-devel>,
	<mailto:pptpclient-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Post: <mailto:pptpclient-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:pptpclient-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/pptpclient-devel>,
	<mailto:pptpclient-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=pptpclient-devel>
List-Id: netdev.vger.kernel.org

Matt Domsch wrote:
>  include/linux/if_ppp.h |   62 +++++++++++++++++--------------------------------

- * 2. Redistributions in binary form must reproduce the above copyright
- *    notice, this list of conditions and the following disclaimer in
- *    the documentation and/or other materials provided with the
- *    distribution.

+ * Redistribution and use in source and binary forms are permitted
+ * provided that the above copyright notice and this paragraph are
+ * duplicated in all such forms and that any documentation,
+ * advertising materials, and other materials related to such
+ * distribution and use acknowledge that the software was developed
+ * by Carnegie Mellon University.

Why do you change the license, especially to something GPL-incompatible?


-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
