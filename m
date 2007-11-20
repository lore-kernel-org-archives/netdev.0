From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: [take8 0/4] dst: Distributed storage.
Date: Tue, 20 Nov 2007 18:24:00 +0300
Message-ID: <1195572240852@2ka.mipt.ru>
References: <asasdasdzxczc036@2ka.mipt.ru>
Reply-To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org, linux-fsdevel@vger.kernel.org
To: lkml <linux-kernel@vger.kernel.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <asasdasdzxczc036@2ka.mipt.ru>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Distributed storage.

I'm pleased to announce the 8'th release of the distributed
storage subsystem (DST). This is a maintenance release and includes
bug fixes only.

DST allows to form a storage on top of local and remote nodes
and combine them into linear or mirroring setup, which in
turn can be exported to remote nodes.

Short changelog:
 * cleanup sysfs files on error path.
	Patch by Chris Madden <chris@reflexsecurity.com>

Overall list of features of the DST can be found on project's homepage:

http://tservice.net.ru/~s0mbre/old/?section=projects&item=dst

Thank you.

Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>


