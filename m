From: James Morris <jmorris@namei.org>
Subject: Re: IPSec kernel oops on ppc64
Date: Fri, 25 Aug 2006 19:15:57 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0608251915140.27896@d.namei>
References: <200608252210.k7PMAxpO025638@faith.austin.ibm.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, gcwilson@us.ibm.com, jmorris@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.sea5.speakeasy.net ([69.17.117.6]:29346 "EHLO
	mail4.sea5.speakeasy.net") by vger.kernel.org with ESMTP
	id S1422879AbWHYXQA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Aug 2006 19:16:00 -0400
To: Joy Latten <latten@austin.ibm.com>
In-Reply-To: <200608252210.k7PMAxpO025638@faith.austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 25 Aug 2006, Joy Latten wrote:

> I installed 2.6.17 + patch-2.6.18-rc4 + 2.6.18-rc4-mm2
> onto two pSeries power 5 (ppc64 lpars) machines. I configured
> IPSec using the configuration listed below. 

Confirming that this does not crash on i686 or x86_64.



- james
-- 
James Morris
<jmorris@namei.org>
