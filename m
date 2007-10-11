From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH][BNX2X] round three - sparse warnings.
Date: Wed, 10 Oct 2007 18:54:55 -0700
Message-ID: <20071010185455.79dafc7b@freepuppy.rosehill>
References: <1192038559.29746.127.camel@eliezer>
	<470D2D7E.8080507@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jeff@garzik.org" <jeff@garzik.org>,
	"Michael Chan" <mchan@broadcom.com>
To: "Eliezer Tamir" <eliezert@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:45634 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753856AbXJKCAo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 22:00:44 -0400
In-Reply-To: <470D2D7E.8080507@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Please fix these...

  CHECK   drivers/net/bnx2x.c
drivers/net/bnx2x_asm.h:62:2: warning: cast removes address space of expression
drivers/net/bnx2x_asm.h:62:2: warning: incorrect type in argument 2 (different address spaces)
drivers/net/bnx2x_asm.h:62:2:    expected void volatile [noderef] <asn:2>*addr
drivers/net/bnx2x_asm.h:62:2:    got unsigned char [usertype] *
drivers/net/bnx2x_asm.h:988:2: warning: cast removes address space of expression
drivers/net/bnx2x_asm.h:988:2: warning: incorrect type in argument 2 (different address spaces)
drivers/net/bnx2x_asm.h:988:2:    expected void volatile [noderef] <asn:2>*addr
drivers/net/bnx2x_asm.h:988:2:    got unsigned char [usertype] *
drivers/net/bnx2x_asm.h:2300:2: warning: cast removes address space of expression
drivers/net/bnx2x_asm.h:2300:2: warning: incorrect type in argument 2 (different address spaces)
drivers/net/bnx2x_asm.h:2300:2:    expected void volatile [noderef] <asn:2>*addr
drivers/net/bnx2x_asm.h:2300:2:    got unsigned char [usertype] *
drivers/net/bnx2x_asm.h:3087:2: warning: cast removes address space of expression
drivers/net/bnx2x_asm.h:3087:2: warning: incorrect type in argument 2 (different address spaces)
drivers/net/bnx2x_asm.h:3087:2:    expected void volatile [noderef] <asn:2>*addr
drivers/net/bnx2x_asm.h:3087:2:    got unsigned char [usertype] *
drivers/net/bnx2x_init_values.h:13:1: warning: cast removes address space of expression
drivers/net/bnx2x_init_values.h:13:1: warning: incorrect type in argument 1 (different address spaces)
drivers/net/bnx2x_init_values.h:13:1:    expected void const volatile [noderef] <asn:2>*addr
drivers/net/bnx2x_init_values.h:13:1:    got unsigned char [usertype] *
drivers/net/bnx2x_init_values.h:14:1: warning: cast removes address space of expression
drivers/net/bnx2x_init_values.h:14:1: warning: incorrect type in argument 1 (different address spaces)
drivers/net/bnx2x_init_values.h:14:1:    expected void const volatile [noderef] <asn:2>*addr
drivers/net/bnx2x_init_values.h:14:1:    got unsigned char [usertype] *
drivers/net/bnx2x_init_values.h:15:1: warning: cast removes address space of expression
drivers/net/bnx2x_init_values.h:15:1: warning: incorrect type in argument 1 (different address spaces)
drivers/net/bnx2x_init_values.h:15:1:    expected void const volatile [noderef] <asn:2>*addr
drivers/net/bnx2x_init_values.h:15:1:    got unsigned char [usertype] *
drivers/net/bnx2x_init_values.h:16:1: warning: cast removes address space of expression
drivers/net/bnx2x_init_values.h:16:1: warning: incorrect type in argument 1 (different address spaces)
drivers/net/bnx2x_init_values.h:16:1:    expected void const volatile [noderef] <asn:2>*addr
drivers/net/bnx2x_init_values.h:16:1:    got unsigned char [usertype] *
drivers/net/bnx2x_init_values.h:17:1: warning: cast removes address space of expression
drivers/net/bnx2x_init_values.h:17:1: warning: incorrect type in argument 1 (different address spaces)
drivers/net/bnx2x_init_values.h:17:1:    expected void const volatile [noderef] <asn:2>*addr
drivers/net/bnx2x_init_values.h:17:1:    got unsigned char [usertype] *
drivers/net/bnx2x_init_values.h:18:1: warning: cast removes address space of expression
drivers/net/bnx2x_init_values.h:18:1: warning: incorrect type in argument 1 (different address spaces)
drivers/net/bnx2x_init_values.h:18:1:    expected void const volatile [noderef] <asn:2>*addr
drivers/net/bnx2x_init_values.h:18:1:    got unsigned char [usertype] *
drivers/net/bnx2x_init_values.h:19:1: warning: cast removes address space of expression
drivers/net/bnx2x_init_values.h:19:1: warning: incorrect type in argument 2 (different address spaces)
drivers/net/bnx2x_init_values.h:19:1:    expected void volatile [noderef] <asn:2>*addr
drivers/net/bnx2x_init_values.h:19:1:    got unsigned char [usertype] *
drivers/net/bnx2x_init_values.h:20:1: warning: cast removes address space of expression
drivers/net/bnx2x_init_values.h:20:1: warning: incorrect type in argument 2 (different address spaces)
drivers/net/bnx2x_init_values.h:20:1:    expected void volatile [noderef] <asn:2>*addr
drivers/net/bnx2x_init_values.h:20:1:    got unsigned char [usertype] *
drivers/net/bnx2x_init_values.h:21:1: warning: cast removes address space of expression
drivers/net/bnx2x_init_values.h:21:1: warning: incorrect type in argument 2 (different address spaces)
drivers/net/bnx2x_init_values.h:21:1:    expected void volatile [noderef] <asn:2>*addr
drivers/net/bnx2x_init_values.h:21:1:    got unsigned char [usertype] *
drivers/net/bnx2x_init_values.h:22:1: warning: cast removes address space of expression
drivers/net/bnx2x_init_values.h:22:1: warning: incorrect type in argument 2 (different address spaces)
drivers/net/bnx2x_init_values.h:22:1:    expected void volatile [noderef] <asn:2>*addr
drivers/net/bnx2x_init_values.h:22:1:    got unsigned char [usertype] *
drivers/net/bnx2x_init_values.h:23:1: warning: cast removes address space of expression
drivers/net/bnx2x_init_values.h:23:1: warning: incorrect type in argument 2 (different address spaces)
drivers/net/bnx2x_init_values.h:23:1:    expected void volatile [noderef] <asn:2>*addr
drivers/net/bnx2x_init_values.h:23:1:    got unsigned char [usertype] *
drivers/net/bnx2x_init_values.h:24:1: warning: cast removes address space of expression
drivers/net/bnx2x_init_values.h:24:1: warning: incorrect type in argument 2 (different address spaces)
drivers/net/bnx2x_init_values.h:24:1:    expected void volatile [noderef] <asn:2>*addr
drivers/net/bnx2x_init_values.h:24:1:    got unsigned char [usertype] *
drivers/net/bnx2x_init_values.h:25:1: warning: cast removes address space of expression
drivers/net/bnx2x_init_values.h:25:1: warning: incorrect type in argument 2 (different address spaces)
drivers/net/bnx2x_init_values.h:25:1:    expected void volatile [noderef] <asn:2>*addr
drivers/net/bnx2x_init_values.h:25:1:    got unsigned char [usertype] *
drivers/net/bnx2x_init_values.h:26:1: warning: cast removes address space of expression
drivers/net/bnx2x_init_values.h:26:1: warning: incorrect type in argument 2 (different address spaces)
drivers/net/bnx2x_init_values.h:26:1:    expected void volatile [noderef] <asn:2>*addr
drivers/net/bnx2x_init_values.h:26:1:    got unsigned char [usertype] *
drivers/net/bnx2x_init_values.h:27:1: warning: cast removes address space of expression
drivers/net/bnx2x_init_values.h:27:1: warning: incorrect type in argument 2 (different address spaces)
drivers/net/bnx2x_init_values.h:27:1:    expected void volatile [noderef] <asn:2>*addr
drivers/net/bnx2x_init_values.h:27:1:    got unsigned char [usertype] *
drivers/net/bnx2x_init_values.h:28:1: warning: cast removes address space of expression
drivers/net/bnx2x_init_values.h:28:1: warning: incorrect type in argument 2 (different address spaces)
drivers/net/bnx2x_init_values.h:28:1:    expected void volatile [noderef] <asn:2>*addr
drivers/net/bnx2x_init_values.h:28:1:    got unsigned char [usertype] *
drivers/net/bnx2x_init_values.h:29:1: warning: cast removes address space of expression
drivers/net/bnx2x_init_values.h:29:1: warning: incorrect type in argument 2 (different address spaces)
drivers/net/bnx2x_init_values.h:29:1:    expected void volatile [noderef] <asn:2>*addr
drivers/net/bnx2x_init_values.h:29:1:    got unsigned char [usertype] *
drivers/net/bnx2x_init_values.h:30:1: warning: cast removes address space of expression
drivers/net/bnx2x_init_values.h:30:1: warning: incorrect type in argument 2 (different address spaces)
drivers/net/bnx2x_init_values.h:30:1:    expected void volatile [noderef] <asn:2>*addr
drivers/net/bnx2x_init_values.h:30:1:    got unsigned char [usertype] *
drivers/net/bnx2x_init_values.h:31:1: warning: cast removes address space of expression
drivers/net/bnx2x_init_values.h:31:1: warning: incorrect type in argument 2 (different address spaces)
drivers/net/bnx2x_init_values.h:31:1:    expected void volatile [noderef] <asn:2>*addr
drivers/net/bnx2x_init_values.h:31:1:    got unsigned char [usertype] *
drivers/net/bnx2x_init_values.h:32:1: warning: cast removes address space of expression
drivers/net/bnx2x_init_values.h:32:1: warning: incorrect type in argument 2 (different address spaces)
drivers/net/bnx2x_init_values.h:32:1:    expected void volatile [noderef] <asn:2>*addr
drivers/net/bnx2x_init_values.h:32:1:    got unsigned char [usertype] *
drivers/net/bnx2x_init_values.h:33:1: warning: cast removes address space of expression
drivers/net/bnx2x_init_values.h:33:1: warning: incorrect type in argument 2 (different address spaces)
drivers/net/bnx2x_init_values.h:33:1:    expected void volatile [noderef] <asn:2>*addr
drivers/net/bnx2x_init_values.h:33:1:    got unsigned char [usertype] *
drivers/net/bnx2x_init_values.h:34:1: warning: cast removes address space of expression
drivers/net/bnx2x_init_values.h:34:1: warning: incorrect type in argument 2 (different address spaces)
drivers/net/bnx2x_init_values.h:34:1:    expected void volatile [noderef] <asn:2>*addr
drivers/net/bnx2x_init_values.h:34:1:    got unsigned char [usertype] *
drivers/net/bnx2x_init_values.h:35:1: warning: cast removes address space of expression
drivers/net/bnx2x_init_values.h:35:1: warning: incorrect type in argument 2 (different address spaces)
drivers/net/bnx2x_init_values.h:35:1:    expected void volatile [noderef] <asn:2>*addr
drivers/net/bnx2x_init_values.h:35:1:    got unsigned char [usertype] *
drivers/net/bnx2x_init_values.h:36:1: warning: cast removes address space of expression
drivers/net/bnx2x_init_values.h:36:1: warning: incorrect type in argument 2 (different address spaces)
drivers/net/bnx2x_init_values.h:36:1:    expected void volatile [noderef] <asn:2>*addr
drivers/net/bnx2x_init_values.h:36:1:    got unsigned char [usertype] *
drivers/net/bnx2x_init_values.h:37:1: warning: cast removes address space of expression
drivers/net/bnx2x_init_values.h:37:1: warning: incorrect type in argument 2 (different address spaces)
drivers/net/bnx2x_init_values.h:37:1:    expected void volatile [noderef] <asn:2>*addr
drivers/net/bnx2x_init_values.h:37:1:    got unsigned char [usertype] *
drivers/net/bnx2x_init_values.h:38:1: warning: cast removes address space of expression
drivers/net/bnx2x_init_values.h:38:1: warning: incorrect type in argument 2 (different address spaces)
drivers/net/bnx2x_init_values.h:38:1:    expected void volatile [noderef] <asn:2>*addr
drivers/net/bnx2x_init_values.h:38:1:    got unsigned char [usertype] *
drivers/net/bnx2x_init_values.h:39:1: warning: cast removes address space of expression
drivers/net/bnx2x_init_values.h:39:1: warning: incorrect type in argument 2 (different address spaces)
drivers/net/bnx2x_init_values.h:39:1:    expected void volatile [noderef] <asn:2>*addr
drivers/net/bnx2x_init_values.h:39:1:    got unsigned char [usertype] *
drivers/net/bnx2x_init_values.h:40:1: warning: cast removes address space of expression
drivers/net/bnx2x_init_values.h:40:1: warning: incorrect type in argument 2 (different address spaces)
drivers/net/bnx2x_init_values.h:40:1:    expected void volatile [noderef] <asn:2>*addr
drivers/net/bnx2x_init_values.h:40:1:    got unsigned char [usertype] *
drivers/net/bnx2x_init_values.h:41:1: warning: cast removes address space of expression
drivers/net/bnx2x_init_values.h:41:1: warning: incorrect type in argument 2 (different address spaces)
drivers/net/bnx2x_init_values.h:41:1:    expected void volatile [noderef] <asn:2>*addr
drivers/net/bnx2x_init_values.h:41:1:    got unsigned char [usertype] *
drivers/net/bnx2x_init_values.h:42:1: warning: cast removes address space of expression
drivers/net/bnx2x_init_values.h:42:1: warning: incorrect type in argument 2 (different address spaces)
drivers/net/bnx2x_init_values.h:42:1:    expected void volatile [noderef] <asn:2>*addr
drivers/net/bnx2x_init_values.h:42:1:    got unsigned char [usertype] *
drivers/net/bnx2x_init_values.h:43:1: warning: cast removes address space of expression
drivers/net/bnx2x_init_values.h:43:1: warning: incorrect type in argument 2 (different address spaces)
drivers/net/bnx2x_init_values.h:43:1:    expected void volatile [noderef] <asn:2>*addr
drivers/net/bnx2x_init_values.h:43:1:    got unsigned char [usertype] *
drivers/net/bnx2x_init_values.h:44:1: warning: cast removes address space of expression
drivers/net/bnx2x_init_values.h:44:1: warning: incorrect type in argument 2 (different address spaces)
drivers/net/bnx2x_init_values.h:44:1:    expected void volatile [noderef] <asn:2>*addr
drivers/net/bnx2x_init_values.h:44:1:    got unsigned char [usertype] *
drivers/net/bnx2x_init_values.h:45:1: warning: cast removes address space of expression
drivers/net/bnx2x_init_values.h:45:1: warning: incorrect type in argument 2 (different address spaces)
drivers/net/bnx2x_init_values.h:45:1:    expected void volatile [noderef] <asn:2>*addr
drivers/net/bnx2x_init_values.h:45:1:    got unsigned char [usertype] *
drivers/net/bnx2x_init_values.h:46:1: warning: cast removes address space of expression
drivers/net/bnx2x_init_values.h:46:1: warning: incorrect type in argument 2 (different address spaces)
drivers/net/bnx2x_init_values.h:46:1:    expected void volatile [noderef] <asn:2>*addr
drivers/net/bnx2x_init_values.h:46:1:    got unsigned char [usertype] *
drivers/net/bnx2x_init_values.h:47:1: warning: cast removes address space of expression
drivers/net/bnx2x_init_values.h:47:1: warning: incorrect type in argument 2 (different address spaces)
drivers/net/bnx2x_init_values.h:47:1:    expected void volatile [noderef] <asn:2>*addr
drivers/net/bnx2x_init_values.h:47:1:    got unsigned char [usertype] *
drivers/net/bnx2x_init_values.h:48:1: warning: cast removes address space of expression
drivers/net/bnx2x_init_values.h:48:1: warning: incorrect type in argument 2 (different address spaces)
drivers/net/bnx2x_init_values.h:48:1:    expected void volatile [noderef] <asn:2>*addr
drivers/net/bnx2x_init_values.h:48:1:    got unsigned char [usertype] *
drivers/net/bnx2x_init_values.h:49:1: warning: cast removes address space of expression
drivers/net/bnx2x_init_values.h:49:1: warning: incorrect type in argument 2 (different address spaces)
drivers/net/bnx2x_init_values.h:49:1:    expected void volatile [noderef] <asn:2>*addr
drivers/net/bnx2x_init_values.h:49:1:    got unsigned char [usertype] *
drivers/net/bnx2x_init_values.h:50:1: warning: cast removes address space of expression
drivers/net/bnx2x_init_values.h:50:1: warning: incorrect type in argument 2 (different address spaces)
drivers/net/bnx2x_init_values.h:50:1:    expected void volatile [noderef] <asn:2>*addr
drivers/net/bnx2x_init_values.h:50:1:    got unsigned char [usertype] *
drivers/net/bnx2x_init_values.h:58:1: warning: cast removes address space of expression
drivers/net/bnx2x_init_values.h:58:1: warning: incorrect type in argument 2 (different address spaces)
drivers/net/bnx2x_init_values.h:58:1:    expected void volatile [noderef] <asn:2>*addr
drivers/net/bnx2x_init_values.h:58:1:    got unsigned char [usertype] *
drivers/net/bnx2x_init_values.h:66:1: warning: cast removes address space of expression
drivers/net/bnx2x_init_values.h:66:1: warning: incorrect type in argument 2 (different address spaces)
drivers/net/bnx2x_init_values.h:66:1:    expected void volatile [noderef] <asn:2>*addr
drivers/net/bnx2x_init_values.h:66:1:    got unsigned char [usertype] *
drivers/net/bnx2x_init_values.h:74:1: warning: cast removes address space of expression
drivers/net/bnx2x_init_values.h:74:1: warning: incorrect type in argument 2 (different address spaces)
drivers/net/bnx2x_init_values.h:74:1:    expected void volatile [noderef] <asn:2>*addr
drivers/net/bnx2x_init_values.h:74:1:    got unsigned char [usertype] *
drivers/net/bnx2x_init_values.h:82:1: warning: cast removes address space of expression
drivers/net/bnx2x_init_values.h:82:1: warning: incorrect type in argument 2 (different address spaces)
drivers/net/bnx2x_init_values.h:82:1:    expected void volatile [noderef] <asn:2>*addr
drivers/net/bnx2x_init_values.h:82:1:    got unsigned char [usertype] *
drivers/net/bnx2x_init_values.h:90:1: warning: cast removes address space of expression
drivers/net/bnx2x_init_values.h:90:1: warning: incorrect type in argument 2 (different address spaces)
drivers/net/bnx2x_init_values.h:90:1:    expected void volatile [noderef] <asn:2>*addr
drivers/net/bnx2x_init_values.h:90:1:    got unsigned char [usertype] *
drivers/net/bnx2x_init_values.h:98:1: warning: cast removes address space of expression
drivers/net/bnx2x_init_values.h:98:1: warning: incorrect type in argument 2 (different address spaces)
drivers/net/bnx2x_init_values.h:98:1:    expected void volatile [noderef] <asn:2>*addr
drivers/net/bnx2x_init_values.h:98:1:    got unsigned char [usertype] *
drivers/net/bnx2x_init_values.h:106:1: warning: cast removes address space of expression
drivers/net/bnx2x_init_values.h:106:1: warning: incorrect type in argument 2 (different address spaces)
drivers/net/bnx2x_init_values.h:106:1:    expected void volatile [noderef] <asn:2>*addr
drivers/net/bnx2x_init_values.h:106:1:    got unsigned char [usertype] *
drivers/net/bnx2x_init_values.h:141:1: warning: cast removes address space of expression
drivers/net/bnx2x_init_values.h:141:1: warning: too many warnings
