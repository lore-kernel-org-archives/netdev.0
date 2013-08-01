From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 0/8] include/net: next set of extern removals
Date: Thu, 01 Aug 2013 13:04:10 +0100
Message-ID: <24958.1375358650@warthog.procyon.org.uk>
References: <cover.1375316912.git.joe@perches.com>
Cc: dhowells@redhat.com, netdev@vger.kernel.org,
	linux-hams@vger.kernel.org, linux-wireless@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-afs@lists.infradead.org
To: Joe Perches <joe@perches.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1375316912.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joe Perches <joe@perches.com> wrote:

> Standardize on no extern use on function prototypes

Ugh.  Can we please standardise on _having_ externs on function prototypes?

David
