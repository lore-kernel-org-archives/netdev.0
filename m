From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.6.9-rc2 12/12] S2io: styling
Date: Mon, 15 Nov 2004 17:34:00 -0500
Message-ID: <41992ED8.7080906@pobox.com>
References: <000e01c4cb5b$20018710$9810100a@S2IOtech.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030709010805020108030200"
Cc: raghavendra.koushik@s2io.com, romieu@fr.zoreil.com, netdev@oss.sgi.com,
        leonid.grossman@s2io.com
Return-path: <netdev-bounce@oss.sgi.com>
To: ravinandan.arakali@s2io.com
In-Reply-To: <000e01c4cb5b$20018710$9810100a@S2IOtech.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------030709010805020108030200
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Ravinandan Arakali wrote:
> Jeff,
> We received couple of comments from Krishna Kumar. Other than that
> we are waiting for further comments. If there are no other, we can
> submit one final patch to address Krishna Kumar's comments.
> 
> In one of your earlier mails(on 10/28), you mentioned "patches pass 
> review".
> Pls let us know.

See attached for the list of patches I've applied.

If I am missing any, please let me know.

	Jeff



--------------030709010805020108030200
Content-Type: text/plain;
 name="linus.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linus.txt"

Please do a

	bk pull bk://gkernel.bkbits.net/s2io

This will update the following files:

 drivers/net/Kconfig     |   11 
 drivers/net/s2io-regs.h |    3 
 drivers/net/s2io.c      | 3114 ++++++++++++++++++++++++++++--------------------
 drivers/net/s2io.h      |  295 ++--
 4 files changed, 2018 insertions(+), 1405 deletions(-)

through these ChangeSets:

<raghavendra.koushik:s2io.com>:
  o S2io: styling
  o S2io: modified loadable parameters
  o S2io: 2 buffer mode with copy
  o S2io: new functions for card restart
  o S2io: two buffer mode
  o S2io: NAPI fix
  o S2io: new txd allocation
  o S2io: module loadable parameters
  o S2io: hardware fixes
  o S2io: optimizations
  o S2io: sw bug fixes
  o S2io: cosmetic changes


--------------030709010805020108030200--
