From: Naoto MATSUMOTO <n-matsumoto@sakura.ad.jp>
Subject: Re: vxlan in Linux kernel 3.7
Date: Fri, 28 Dec 2012 09:46:49 +0900
Message-ID: <20121228094648.5F53.C42C3789@sakura.ad.jp>
References: <A3CA455BB4F1DA4E92CB43AAF0E4BB1D0667E12B@MX01A.corp.emc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Qin, Xiaohong" <Xiaohong.Qin@emc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.sakura.ad.jp ([210.224.172.11]:36339 "EHLO
	mail.sakura.ad.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752333Ab2L1Aqq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Dec 2012 19:46:46 -0500
In-Reply-To: <A3CA455BB4F1DA4E92CB43AAF0E4BB1D0667E12B@MX01A.corp.emc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi Qin

FYI(For Your Information)

A First Look At VXLAN over Infiniband Network On Linux 3.7-rc7 & iproute2
http://slidesha.re/TsCKWc


On Thu, 27 Dec 2012 13:42:51 -0500
"Qin, Xiaohong" <Xiaohong.Qin@emc.com> wrote:

> Hi All,
> 
> I have installed kernel 3.7 on my Linux box, see the following uname -a output,
> 
> uname -a
> Linux c210-m2-sib-3 3.7.0-030700-generic #201212102335 SMP Tue Dec 11 04:36:24 UTC 2012 x86_64 x86_64 x86_64 GNU/Linux
> 
> Does that mean I've got VXLAN module loaded or I still need to go through some extra steps to enable or configure it? Do you have any VXLAN setup or configuration document by chance?
> 
> Thanks.
> 
> Dennis Qin
> 
> P.S. If this is not the right place to ask this kind of questions, please let me know which mailing list I should use.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
SAKURA Internet Inc. / Senior Researcher
Naoto MATSUMOTO <n-matsumoto@sakura.ad.jp>
SAKURA Research Center <http://research.sakura.ad.jp/>
