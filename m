From: "John W. Linville" <linville@redhat.com>
Subject: [ANNOUNCE] fedora-netdev kernel repository
Date: Mon, 14 Nov 2005 15:51:10 -0500
Message-ID: <20051114205110.GK25755@redhat.com>
Reply-To: linville@redhat.com, linville@tuxdriver.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932113AbVKNUv0@vger.kernel.org>
To: fedora-list@redhat.com, fedora-announce-list@redhat.com,
	fedora-devel-list@redhat.com
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fedora-netdev!

This message is to announce the availability of a new Fedora-based
kernel repository.  The kernels available there are based upon
the standard Fedora kernels, with the addition of current upstream
networking patches which are more recent than the Fedora kernel's
upstream base.  More information is available here:

	http://people.redhat.com/linville/kernels/fedora-netdev/

The purpose of this repository is two-fold: 1) to make bleeding-edge
linux kernel networking developments available to Fedora users who
need or want access to them; and, 2) to open-up the Fedora user
base as a better testing resource for the kernel netdev community.
I hope this will prove to be a win-win situation for both camps.

If you are a Fedora user with an interest or need for the latest
developments in Linux kernel networking, then _please_ try the
kernels from this repository.  Your testing and feedback is greatly
appreciated, desperately requested, and graciously accepted.
Thanks in advance!

Please feel free to contact me at this address regarding these
kernels or other Fedora-related issues (especially networking).
If your interest is coming from the netdev/upstream side of the house,
you may want to contact me as linville@tuxdriver.com instead.

Thanks,

John

P.S.  For those who just want to cut to the chase, do this (as root):

   cd /etc/yum.repos.d
   wget http://people.redhat.com/linville/kernels/fedora-netdev/fedora-netdev.repo
   yum update

-- 
John W. Linville
linville@redhat.com
