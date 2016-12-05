From: Joe Perches <joe@perches.com>
Subject: [PATCH resend 0/8] irda: w83977af_ir: Neatening
Date: Mon,  5 Dec 2016 11:00:40 -0800
Message-ID: <cover.1480963809.git.joe@perches.com>
Cc: Arnd Bergmann <arnd@arndb.de>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Samuel Ortiz <samuel@sortiz.org>, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On top of Arnd's overly long udelay patch because I noticed a
misindented block.

Even though I haven't turned on the netwinder in a box in the
garage in who knows how long, if this device is still used somewhere,
might as well neaten the code too.

Joe Perches (8):
  irda: w83977af_ir: whitespace neatening
  irda: w83977af_ir: More whitespace neatening
  irda: w83977af_ir: Remove and add blank lines
  irda: w83977af_ir: Neaten pointer comparisons
  irda: w83977af_ir: Use the common brace style
  irda: w83977af_ir: Parenthesis alignment
  irda: w83977af_ir: Neaten logging
  irda: w83977af_ir: Fix misindented block

 drivers/net/irda/w83977af_ir.c | 669 ++++++++++++++++++++---------------------
 1 file changed, 333 insertions(+), 336 deletions(-)

Resend:  Addressed Sergei's "Removing, really? :-) nudge"
-- 
2.10.0.rc2.1.g053435c
