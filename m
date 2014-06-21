From: Ondrej Zary <linux@rainbow-software.org>
Subject: [PATCH 0/11 v2] tlan: Link handling improvements and Olicom fixes
Date: Sat, 21 Jun 2014 16:47:45 +0200
Message-ID: <1403362076-7777-1-git-send-email-linux@rainbow-software.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Samuel Chessman <chessman@tux.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This patch series improves link handling in tlan driver, allowing the
cable to be (un)plugged anytime and NetworkManager to work properly.

Also there are some bugfixes related to Olicom OC-2326 card.

-- 
Ondrej Zary
