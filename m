From: "Scott J. Goldman" <scottjg@vmware.com>
Subject: [PATCH net-next] vmxnet3: fix compilation when RSS is disabled
Date: Sat, 27 Nov 2010 12:33:54 -0800
Message-ID: <1290890035-32285-1-git-send-email-scottjg@vmware.com>
Cc: pv-drivers@vmware.com, randy.dunlap@oracle.com
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-next@vger.kernel.org
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since this was reported on linux-next, we may want to merge it there too.
