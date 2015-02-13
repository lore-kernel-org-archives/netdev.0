From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH 1/1] tun: change speed from 10M to dynamically configured
Date: Fri, 13 Feb 2015 13:32:23 -0800
Message-ID: <54DE6D67.5000601@hp.com>
References: <1423808353-8722-1-git-send-email-Yanjun.Zhu@windriver.com> <1423808353-8722-2-git-send-email-Yanjun.Zhu@windriver.com> <20150213212830.GA29912@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mst@redhat.com, jasowang@redhat.com,
	viro@zeniv.linux.org.uk, davem@davemloft.net,
	sergei.shtylyov@cogentembedded.com, jonathon.reinhart@gmail.com
To: Francois Romieu <romieu@fr.zoreil.com>,
	Zhu Yanjun <Yanjun.Zhu@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3425.houston.hp.com ([15.201.208.53]:9398 "EHLO
	g4t3425.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752153AbbBMVc1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Feb 2015 16:32:27 -0500
In-Reply-To: <20150213212830.GA29912@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is perhaps as much a bug in the monitoring tools as anything else, 
but I have come across (versions of) software - such as collectl I think 
- which when presented with counters indicating a data rate higher than 
the reported link rate of the interface get somewhat cranky.

rick jones
