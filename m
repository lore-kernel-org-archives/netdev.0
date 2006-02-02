From: Mark Brown <broonie@sirena.org.uk>
Subject: [patch 0/2] natsemi: NAPI and a bugfix
Date: Thu, 02 Feb 2006 23:27:26 +0000
Message-ID: <20060202233909.426660000@lorien.sirena.org.uk>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932486AbWBBXxk@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>, Tim Hockin <thockin@hockin.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

These patches provide a series of updates to the natsemi driver: the
NAPI patch I've submitted before and a workaround for an issue with the
hardware that is easier to provoke at higher data rates.

  1/2: Convert the driver to NAPI
  2/2: Fix hardware issue with RX state machine lock up

--
"You grabbed my hand and we fell into it, like a daydream - or a fever."
