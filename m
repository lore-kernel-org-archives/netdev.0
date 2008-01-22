From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: [0/4] DST: Distributed storage: Succumbed to live ant.
Date: Tue, 22 Jan 2008 22:38:26 +0300
Message-ID: <1201030706738@2ka.mipt.ru>
References: <20080122001122.GA21861@2ka.mipt.ru>
Reply-To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: lkml <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753499AbYAVTjM@vger.kernel.org>
In-Reply-To: <20080122001122.GA21861@2ka.mipt.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Distributed storage: Succumbed to live ant.

I'm pleased to announce the 14'th release of the distributed
storage subsystem (DST).

DST allows to form a storage on top of local and remote nodes
and combine them into linear or mirroring setup, which in
turn can be exported to remote nodes.

This is a maintenance release only.

Short changelog:
 * do not allocate big enough address structure on stack during
	local export node initialization
	Thanks to Serge Leschinsky and Konstantin Kalin for testing.

Overall list of features of the DST can be found on project's homepage:

http://tservice.net.ru/~s0mbre/old/?section=projects&item=dst

DST is also exported as a git tree available for clone and pull from
http://tservice.net.ru/~s0mbre/archive/dst/dst.git

Thank you.

Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
