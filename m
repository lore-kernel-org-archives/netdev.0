From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: docs: document multiqueue tuntap API
Date: Tue, 05 Mar 2013 23:54:01 -0500 (EST)
Message-ID: <20130305.235401.548455441771005291.davem@davemloft.net>
References: <1362539123-24863-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: maxk@qti.qualcomm.com, rob@landley.net, linux-doc@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	mst@redhat.com, hkchu@google.com
To: jasowang@redhat.com
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <1362539123-24863-1-git-send-email-jasowang@redhat.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jason Wang <jasowang@redhat.com>
Date: Wed,  6 Mar 2013 11:05:23 +0800

> Signed-off-by: Jason Wang <jasowang@redhat.com>

Please fix these warnings emitted by GIT:

Applying: net: docs: document multiqueue tuntap API
/home/davem/src/GIT/net/.git/rebase-apply/patch:31: space before tab in indent.
  	struct ifreq ifr;
/home/davem/src/GIT/net/.git/rebase-apply/patch:32: space before tab in indent.
  	int fd, err, i;
/home/davem/src/GIT/net/.git/rebase-apply/patch:34: space before tab in indent.
  	if (!dev)
/home/davem/src/GIT/net/.git/rebase-apply/patch:35: space before tab in indent.
  		return -1;
/home/davem/src/GIT/net/.git/rebase-apply/patch:37: space before tab in indent.
  	memset(&ifr, 0, sizeof(ifr));
warning: squelched 29 whitespace errors
warning: 34 lines add whitespace errors.
