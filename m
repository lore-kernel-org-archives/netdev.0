From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bug 8934] System freeze when restarting network connection
 with Broadcom driver
Date: Sat, 25 Aug 2007 09:08:31 -0700
Message-ID: <20070825090831.73772b99.akpm@linux-foundation.org>
References: <bug-8934-27@http.bugzilla.kernel.org/>
	<20070825102624.732A810807E@picon.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, casteyde.christian@free.fr,
	mchan@broadcom.com
To: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:51153 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751908AbXHYQIh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Aug 2007 12:08:37 -0400
In-Reply-To: <20070825102624.732A810807E@picon.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 25 Aug 2007 03:26:24 -0700 (PDT) bugme-daemon@bugzilla.kernel.org wrote:

> http://bugzilla.kernel.org/show_bug.cgi?id=8934

Various nasty box-killing things happening here and
http://bugzilla.kernel.org/show_bug.cgi?id=8937 might be related. 

Michal, 8934 (at least) is a post-2.6.22 regression - can you please add it
to the list?

