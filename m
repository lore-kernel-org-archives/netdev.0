From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: [0/4] DST: Distributed storage: Groundhogs strike back: no New Year for humans
Date: Wed, 26 Dec 2007 14:22:51 +0300
Message-ID: <11986681713055@2ka.mipt.ru>
References: <20071226004434.GA21861@2ka.mipt.ru>
Reply-To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: lkml <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from matrixpower.ru ([195.178.208.66]:49646 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755472AbXLZLXA convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Dec 2007 06:23:00 -0500
In-Reply-To: <20071226004434.GA21861@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Distributed storage: Groundhogs strike back: no New Year for humans

I'm pleased to announce the 13'th release of the distributed
storage subsystem (DST).

DST allows to form a storage on top of local and remote nodes
and combine them into linear or mirroring setup, which in
turn can be exported to remote nodes.

Short changelog:
 * mirroring algorithm improvements
 * debug cleanups
 * extended mirroring initialization
 * documentation update
 * name is 'Groundhogs strike back: no New Year for humans' now

Overall list of features of the DST can be found on project's homepage:

http://tservice.net.ru/~s0mbre/old/?section=projects&item=dst

DST is also exported as a git tree available for clone and pull from
http://tservice.net.ru/~s0mbre/archive/dst/dst.git

Thank you.

Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>


