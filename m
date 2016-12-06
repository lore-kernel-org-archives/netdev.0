From: Joe Perches <joe@perches.com>
Subject: [PATCH v3 0/7] irda: w83977af_ir: Neatening
Date: Tue,  6 Dec 2016 10:15:59 -0800
Message-ID: <cover.1481047792.git.joe@perches.com>
Cc: Arnd Bergmann <arnd@arndb.de>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Samuel Ortiz <samuel@sortiz.org>, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Originally on top of Arnd's overly long udelay patches because I
noticed a misindented block.  That's now already fixed along with some
other whitespace problems.  These patches are the remainder style
issues from my original series.

Even though I haven't turned on the netwinder in a box in the
garage in who knows how long, if this device is still used somewhere,
might as well neaten the code too.

Joe Perches (7):
  irda: w83977af_ir: Whitespace neatening
  irda: w83977af_ir: More whitespace neatening
  irda: w83977af_ir: Remove and add blank lines
  irda: w83977af_ir: Neaten pointer comparisons
  irda: w83977af_ir: Use the common brace style
  irda: w83977af_ir: Parenthesis alignment
  irda: w83977af_ir: Neaten logging

 drivers/net/irda/w83977af_ir.c | 323 ++++++++++++++++++++---------------------
 1 file changed, 160 insertions(+), 163 deletions(-)

-- 
2.10.0.rc2.1.g053435c
