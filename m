From: Jiri Slaby <jirislaby@gmail.com>
Subject: Re: select(0, ..) is valid ?
Date: Tue, 15 May 2007 19:36:36 +0200
Message-ID: <4649EFA4.9060000@gmail.com>
References: <1179250159.2836.117.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lkml <linux-kernel@vger.kernel.org>,
	Christoph Lameter <clameter@sgi.com>,
	Andrew Morton <akpm@linux-foundation.org>
To: Badari Pulavarty <pbadari@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:15795 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758668AbXEORgT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 May 2007 13:36:19 -0400
Received: by ug-out-1314.google.com with SMTP id 44so1630491uga
        for <netdev@vger.kernel.org>; Tue, 15 May 2007 10:36:18 -0700 (PDT)
In-Reply-To: <1179250159.2836.117.camel@dyn9047017100.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Badari Pulavarty napsal(a):
> Hi,
> 
> Is select(0, ..) is a valid operation ?

Yes, it was (is) sometimes used for measuring (sleeping for) short time slices.

regards,
-- 
http://www.fi.muni.cz/~xslaby/            Jiri Slaby
faculty of informatics, masaryk university, brno, cz
e-mail: jirislaby gmail com, gpg pubkey fingerprint:
 B674 9967 0407 CE62 ACC8  22A0 32CC 55C3 39D4 7A7E
