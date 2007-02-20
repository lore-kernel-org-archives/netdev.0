From: John Rose <johnrose@austin.ibm.com>
Subject: Re: [PATCH] ehea: dynamic add / remove port
Date: Tue, 20 Feb 2007 11:56:56 -0600
Message-ID: <1171994215.22669.8.camel@sinatra.austin.ibm.com>
References: <200702201828.20808.ossthema@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Thomas Klein <osstklei@de.ibm.com>, stefan.rocher@de.ibm.com,
	Christoph Raisch <RAISCH@de.ibm.com>,
	Marcus Eder <MEDER@de.ibm.com>, netdev <netdev@vger.kernel.org>
To: Jan-Bernd Themann <ossthema@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:36689 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932989AbXBTR7y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Feb 2007 12:59:54 -0500
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l1KHxrRt003294
	for <netdev@vger.kernel.org>; Tue, 20 Feb 2007 12:59:53 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by westrelay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l1KHxrRU542556
	for <netdev@vger.kernel.org>; Tue, 20 Feb 2007 10:59:53 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l1KHxreW004689
	for <netdev@vger.kernel.org>; Tue, 20 Feb 2007 10:59:53 -0700
In-Reply-To: <200702201828.20808.ossthema@de.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Jan-

> Would that interface be sufficient for the userspace application?

This looks great!  Two questions.  I would assume that the of_device
results in a "devspec" file in the sysfs directory for the port?  Also,
is there a way to correlate a logical port to an ethernet interface
(eth0, etc)?

Thanks!
John

