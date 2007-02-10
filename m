From: Robert Hancock <hancockr@shaw.ca>
Subject: Re: forcedeth problems on 2.6.20-rc6-mm3
Date: Fri, 09 Feb 2007 22:40:58 -0600
Message-ID: <45CD4CDA.7050600@shaw.ca>
References: <45C6BCE5.90103@shaw.ca>
 <20070204213603.a5bce839.akpm@linux-foundation.org> <45C6C531.20508@shaw.ca>
 <20070204221741.63152cbe.akpm@linux-foundation.org>
 <523e55a00702081326j43de05e3hdd8cf35e946eae9@mail.gmail.com>
 <45CBE30D.5030006@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Ford <firefighterblu3@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shawidc-mo1.cg.shawcable.net ([24.71.223.10]:28116 "EHLO
	pd2mo2so.prod.shaw.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753053AbXBJElB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Feb 2007 23:41:01 -0500
In-reply-to: <45CBE30D.5030006@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ayaz Abdulla wrote:
> For all those who are having issues, please try out the attached patch.
> 
> Ayaz

Seems to solve the problem for me (not heavily tested, but certainly 
isn't totally dead as it was before).

-- 
Robert Hancock      Saskatoon, SK, Canada
To email, remove "nospam" from hancockr@nospamshaw.ca
Home Page: http://www.roberthancock.com/

