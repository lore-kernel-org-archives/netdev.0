From: Joe Perches <joe@perches.com>
Subject: [PATCH 0/8] irda: w83977af_ir: Neatening
Date: Thu, 24 Nov 2016 11:10:27 -0800
Message-ID: <cover.1480014088.git.joe@perches.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Samuel Ortiz <samuel@sortiz.org>,
        linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On top of Arnd's overly long udelay patch because I noticed a
misindented block.

Even though I haven't turned on the netwinder in a box in in the
garage in who knows how long, if this device is still used somewhere,
might as well neaten the code too.

Joe Perches (8):
  irda: w83977af_ir: whitespace neatening
  irda: w83977af_ir: More whitespace neatening
  irda: w83977af_ir: Remove unnecessary blank lines
  irda: w83977af_ir: Neaten pointer comparisons
  irda: w83977af_ir: Use the common brace style
  irda: w83977af_ir: Parenthesis alignment
  irda: w83977af_ir: Neaten logging
  irda: w83977af_ir: Fix misindented block

 drivers/net/irda/w83977af_ir.c | 669 ++++++++++++++++++++---------------------
 1 file changed, 333 insertions(+), 336 deletions(-)

-- 
2.10.0.rc2.1.g053435c
