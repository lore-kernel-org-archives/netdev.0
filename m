From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PULL] vhost: cleanups and fixes
Date: Mon, 1 Jun 2015 21:18:55 +0200
Message-ID: <20150601211854-mutt-send-email-mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	mikko.rapeli@iki.fi, mst@redhat.com
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following changes since commit c65b99f046843d2455aa231747b5a07a999a9f3d:

  Linux 4.1-rc6 (2015-05-31 19:01:07 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/mst/vhost.git tags/for_linus

for you to fetch changes up to 8a7b19d8b542b87bccc3eaaf81dcc90a5ca48aea:

  include/uapi/linux/virtio_balloon.h: include linux/virtio_types.h (2015-06-01 15:46:54 +0200)

----------------------------------------------------------------
virtio: last-minute fix for 4.1

This tweaks an exported user-space header to fix
build breakage for userspace using it.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>

----------------------------------------------------------------
Mikko Rapeli (1):
      include/uapi/linux/virtio_balloon.h: include linux/virtio_types.h

 include/uapi/linux/virtio_balloon.h | 1 +
 1 file changed, 1 insertion(+)
