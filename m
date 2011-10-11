From: Stephen Hemminger <shemminger@vyatta.com>
Subject: iproute2 back at kernel.org
Date: Tue, 11 Oct 2011 16:59:08 -0700
Message-ID: <20111011165908.0d6ed7de@nehalam.linuxnetplumber.net>
References: <20110916103031.7f22b35f@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: base64
Cc: netdev@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:55081 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751344Ab1JKX7K (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Oct 2011 19:59:10 -0400
Received: from localhost (localhost.localdomain [127.0.0.1])
	by mail.vyatta.com (Postfix) with ESMTP id A3CCD1410048
	for <netdev@vger.kernel.org>; Tue, 11 Oct 2011 16:59:09 -0700 (PDT)
Received: from mail.vyatta.com ([127.0.0.1])
	by localhost (mail.vyatta.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id UhijYpCJ0mmc for <netdev@vger.kernel.org>;
	Tue, 11 Oct 2011 16:59:09 -0700 (PDT)
Received: from nehalam.linuxnetplumber.net (static-50-53-80-93.bvtn.or.frontiernet.net [50.53.80.93])
	by mail.vyatta.com (Postfix) with ESMTPSA id 42CC61410034
	for <netdev@vger.kernel.org>; Tue, 11 Oct 2011 16:59:09 -0700 (PDT)
In-Reply-To: <20110916103031.7f22b35f@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

LS0tLS1CRUdJTiBQR1AgU0lHTkVEIE1FU1NBR0UtLS0tLQ0KSGFzaDogU0hBMjU2DQoNCk5vdyB0
aGF0IGtlcm5lbC5vcmcgaXMgYmFjayBvbmxpbmUsIHRoZSBpcHJvdXRlMiByZXBvc2l0b3J5IGlz
IGJhY2sNCmF0IGl0J3Mgb2xkIGxvY2F0aW9uLg0KICAgZ2l0Oi8vZ2l0Lmtlcm5lbC5vcmcvcHVi
L3NjbS9saW51eC9rZXJuZWwvZ2l0L3NoZW1taW5nZXIvaXByb3V0ZTINCg0KSSBoYXZlIGZyb3pl
biBhbmQgdGFnZ2VkIHRoZSB2My4wIHJlbGVhc2UsIGJ1dCBkb24ndCBoYXZlIGEgZ29vZCBwbGFj
ZQ0KdG8gcHV0IHRoZSB0YXIgYmFsbCB5ZXQgKHN0YXkgdHVuZWQpLiBBbHNvIHRoZSBzaWduaW5n
IGtleSBmb3IgdGhlIHJlbGVhc2UNCndpbGwgYmUgY2hhbmdpbmcuDQotLS0tLUJFR0lOIFBHUCBT
SUdOQVRVUkUtLS0tLQ0KVmVyc2lvbjogR251UEcgdjEuNC4xMSAoR05VL0xpbnV4KQ0KDQppUUlj
QkFFQkNBQUdCUUpPbE5oTUFBb0pFSUNuZjJDVnplUiszdm9QL0EwT3dTcnphR1pJZjhWTXBQd3F2
aGdNDQp4WjZFVWFzZ0lSUFRxZDBGTkRrY29OVHFUOGhJVUwrQ2QyNm54cDA5b3lTelBLWXFobldS
MFhIUkxEclBFdWlyDQpkaGlmejZXWFVGMVpxb0taVTdoczFadGcvdHZNM1M5blY4U0kxaEtOTXA4
dHZ4TlM1cDFrYWRUUmIreWl5ZWp6DQpvWGo5ZlY3dDhUQ1R3TDBmemRGeG83ZFRldUNZbzZxMW51
c2JYVndHRlV3cUNkL2krWEFQR1BtQ094L0tzWVRmDQpGL0p1c2VIQml5bFZLdEJNYkkvTzFhdDRj
NnZ4d2loNktrWGR3RkZ4VmVEbEZaSEQrU3JvU241VWp4RytDdnZCDQp2c0F0NkwwbTNmYklIVmtz
dzlVTGJNemVHVTUvT2RXTXd4ZTZrckh1bFhKZFM4Qld2U1dhT1ZmRVdvcWRHb0dUDQpmYjJxdlpS
eHN2VGlmaHhVbktkN0oxejJXZkZLYit6a3Y0WXlOV2p0TTBCSkRvemt0YTRKc3VSV01CbGhoU2Jy
DQozQkE4bVBJUXlSNGIrUXc2NHBHR2FhbHgwM1JOQ2NkVVNFYlJLUFZlZjZSWGRFRjZNSzRVQXVI
clBkbnp3V3JNDQprN3F2QkMwUnlrMnhkcTllSlp2NGlDc0M5TE4vK2NvcE5BaVlEb29TYXMvdytQ
ZzNQSEtncFBUVk5kSE1Tb3dJDQpnT2hTQU5oRzlxWVhoaEpFVFZUV21SREc4bk1ydVM2UklNMFho
eEhZR0pIdGdaYUtRQUpoQ3c0QmdIZUVKeWxSDQpsNUt3ckVZV2s0MlRCVXFreGRMYWJkYVd3T0FQ
a0xxM3VqREtnMFJNZHcveVcrcFdyUWdHWi9GNlBRbGplbFZLDQpWQ2xrUDdBQ0JrRTZFSWZlVlNl
Mg0KPVJIOE8NCi0tLS0tRU5EIFBHUCBTSUdOQVRVUkUtLS0tLQ0K
