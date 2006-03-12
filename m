From: Mark Brown <broonie@sirena.org.uk>
Subject: [patch 0/4] natsemi: Aculab E1/T1 PMXc Carrier Card support
Date: Sun, 12 Mar 2006 19:22:59 +0000
Message-ID: <20060312192259.929734000@mercator.sirena.org.uk>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932212AbWCLVai@vger.kernel.org>
To: Tim Hockin <thockin@hockin.org>, Jeff Garzik <jgarzik@pobox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch series against the upstream branch of netdev-2.6 adds support
for these boards to the natsemi driver.  It implements some new
functionality required by the boards and enables the appropriate
settings when such a board is detected.

--
"You grabbed my hand and we fell into it, like a daydream - or a fever."
